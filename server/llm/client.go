package llm

import (
	"bytes"
	"encoding/json"
	"fmt"
	"intDocument/server/config"
	"io"
	"net/http"
	"strings"
)

type OllamaClient struct {
	BaseURL string
	Model   string
}

func NewOllamaClient() *OllamaClient {
	return &OllamaClient{
		BaseURL: config.Config.OllamaURL,
		Model:   config.Config.OllamaModel,
	}
}

type GenerateRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
	Stream bool   `json:"stream"`
}

type GenerateResponse struct {
	Response string `json:"response"`
	Done     bool   `json:"done"`
}

func (c *OllamaClient) generate(prompt string) (string, error) {
	reqBody := GenerateRequest{
		Model:  c.Model,
		Prompt: prompt,
		Stream: false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	resp, err := http.Post(c.BaseURL+"/api/generate", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("failed to connect to Ollama: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("ollama API error: %s", string(body))
	}

	var response GenerateResponse
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		return "", err
	}

	return response.Response, nil
}

func (c *OllamaClient) SummarizeText(text string) (string, error) {
	prompt := fmt.Sprintf("Summarize the following technical introduction text into a concise paragraph suitable for a design document introduction:\n\n%s", text)
	return c.generate(prompt)
}

func (c *OllamaClient) ExtractSpecifications(text string) (map[string]string, error) {
	// Instruct LLM to return JSON
	prompt := fmt.Sprintf(`Extract the key technical specifications (like Satellite Class, Orbit, Mass, Power, Life, etc.) from the text below.
	Return ONLY a JSON object where keys are the specification names and values are the values. Do not include markdown formatting or extra text.

	Text:
	%s`, text)

	response, err := c.generate(prompt)
	if err != nil {
		return nil, err
	}

	// Clean up response if it contains markdown code blocks
	response = strings.TrimPrefix(response, "```json")
	response = strings.TrimPrefix(response, "```")
	response = strings.TrimSuffix(response, "```")
	response = strings.TrimSpace(response)

	var specs map[string]string
	if err := json.Unmarshal([]byte(response), &specs); err != nil {
		// Fallback: If JSON parsing fails, return a simple map with the raw response for manual review,
		// or try to parse line by line. For now, let's return error or empty.
		fmt.Printf("Failed to parse JSON specs: %v\nRaw Response: %s\n", err, response)
		return nil, fmt.Errorf("failed to parse specifications from LLM response")
	}

	return specs, nil
}

func (c *OllamaClient) IdentifySections(tocText string) (map[string]int, error) {
	prompt := fmt.Sprintf(`Analyze the following text which contains the Table of Contents (TOC) of a document.
	Identify the page numbers for the following sections:
	1. Introduction
	2. Specifications (or Subsystem Specifications, Technical Specifications)
	3. Block Diagram (or System Block Diagram)

	Return ONLY a JSON object with keys "Introduction", "Specifications", "Block Diagram" and values as the integer page number.
	If a section is not found, do not include it in the JSON.
	Do not include markdown formatting, code blocks, or extra text. Just the raw JSON.

	Text:
	%s`, tocText)

	response, err := c.generate(prompt)
	if err != nil {
		return nil, err
	}

	// Clean up response if it contains markdown code blocks
	response = strings.TrimPrefix(response, "```json")
	response = strings.TrimPrefix(response, "```")
	response = strings.TrimSuffix(response, "```")
	response = strings.TrimSpace(response)

	var sections map[string]int
	if err := json.Unmarshal([]byte(response), &sections); err != nil {
		fmt.Printf("Failed to parse JSON sections: %v\nRaw Response: %s\n", err, response)
		return nil, fmt.Errorf("failed to parse sections from LLM response")
	}

	return sections, nil
}

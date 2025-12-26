# IST Document Generator - Design Document

## 1. Architecture Overview

The IST (Integrated Satellite Test) Document Generator is a web-based application designed to facilitate the creation, editing, and compilation of complex satellite testing documentation. It employs a modern web architecture decoupling the frontend editing experience from the backend document generation logic.

### High-Level Components

*   **Frontend**: A Flutter Web application serving as the user interface for document editing. It runs in the browser and communicates with the backend via a REST API.
*   **Backend**: A Go (Golang) server that handles API requests, manages data persistence, and orchestrates the document compilation process.
*   **Database**: Bitcask (via `go.mills.io/bitcask/v2`), an embedded key-value store used to persist document structure and content.
*   **Compiler**: Typst, a programmable markup language for typesetting, used to generate high-quality PDFs from the stored data.

## 2. Document Lifecycle

The lifecycle of a document involves three main stages: Creation/Editing, Storage, and Generation.

### 2.1 Creation & Editing (UI -> API)

1.  **User Interaction**: The user interacts with the Flutter web client (`client/`).
2.  **State Management**: The app uses `Provider` to manage the state of the currently selected document and its content.
3.  **API Requests**: Changes are sent to the server using standard HTTP POST requests with JSON payloads.
    *   *Service*: `client/lib/services/api_service.dart`
    *   *Endpoints*: `/addDocument`, `/addDocumentDetails`, `/addContent`, etc.

### 2.2 Storage (API -> DB)

1.  **Request Handling**: The Go server (`server/client/EntryPoint.go`) receives the JSON request using the Gin web framework.
2.  **Data Models**: JSON is unmarshalled into Go structs defined in `server/database/Structures.go`.
    *   Key structures include `DocumentDetails`, `SubsystemDetails`, and `Content`.
3.  **Persistence**: The server interacts with the Bitcask database (`server/database/`) to store the data associated with the document ID.

### 2.3 Generation (DB -> Typst -> PDF)

This is the core functionality where structured data is transformed into a final PDF.

1.  **Trigger**: The user clicks "Generate PDF" in the UI, hitting the `/compileDocument` endpoint.
2.  **Controller Logic**: The server (`server/typst/Controller.go`) initiates the build process:
    *   Creates a temporary directory for the compilation (e.g., `./<clientID>/`).
    *   Retrieves all document data (Introduction, Test Details, etc.) from the database.
3.  **Typst Construction**: The server programmatically constructs a `.typ` file string.
    *   It iterates through the defined document sections (Intro, Checkout, etc.).
    *   It uses helper functions in `server/typst/AddContent.go` to convert generic content blocks into Typst syntax.
4.  **Compilation**:
    *   The server executes the `typst compile main.typ` command via `os/exec`.
    *   The resulting `main.pdf` is read into memory.
5.  **Delivery**: The PDF binary is Base64 encoded and sent back to the client for download.

## 3. Document Structure

The IST document follows a strict hierarchical structure enforced by the backend logic (`server/typst/Introduction.go`, `TestDetails.go`, etc.).

### 3.1 Metadata
*   **Document Details**: Title, Number, Prepared By, Approvers, etc.
*   **Subsystem Details**: Name, Satellite Class, Satellite Image.

### 3.2 Sections
The document is divided into fixed chapters, populated with dynamic content:
1.  **Introduction**: Abstract, Acronyms, Subsystem Specification, Telemetry/Telecommand lists.
2.  **Checkout Details**: Interface requirements, Safety protocols, Test philosophy.
3.  **Test Details**: Test Matrix, Test Plan, Procedures.
4.  **Annexure**: EID Documents, Test Results.

### 3.3 Content Blocks
Each section is composed of a list of `Content` items. The `addContent` function (`server/typst/AddContent.go`) handles the translation of these items based on their `ContentType`:

| Content Type | UI Input | Typst Output | Description |
| :--- | :--- | :--- | :--- |
| **Text** | String | Text paragraph | Standard text blocks. |
| **RichText** | Delta JSON | Formatted Text | Supports bold, italic, etc. (Parsed from Quill/Flutter editor). |
| **Image** | Base64 String | `#figure(image(...))` | Images are decoded and saved to a temp `images/` directory before compiling. |
| **Table** | CSV/Grid Data | `#table(...)` | Dynamic tables with captions. |
| **Code** | String | `#raw(...)` | Code blocks. |
| **Excel** | Excel File | `#table(...)` | Parses Excel data to generate Typst tables. |
| **PDF** | Base64 String | `image("file.pdf")` | Embeds external PDF pages as images. |

## 4. Key Technologies & Decisions

*   **REST over gRPC**: While legacy traces of `protobuf` exist in the `Makefile`, the active implementation uses a pure JSON/REST architecture for simplicity and ease of integration with the Flutter Web client.
*   **Embedded Database**: Bitcask was chosen for its high performance and simplicity, removing the need for an external database server for this self-contained application.
*   **Typst**: Chosen over LaTeX for its faster compilation times and more approachable scripting capabilities, allowing the Go server to generate complex layouts dynamically.

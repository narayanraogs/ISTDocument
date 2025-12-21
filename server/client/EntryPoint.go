package client

import (
	"fmt"
	"io/fs"
	"net/http"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

var clientMap = make(map[string]*client)

type client struct {
	global global.ClientGlobal
}

func Listen(web fs.FS, port string) {

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{"POST", "OPTIONS"},
		AllowHeaders: []string{"Origin", "Content-Type", "ClientID", "TimeStamp"},
		MaxAge:       12 * time.Hour,
	}))

	// Apply the OPTIONS middleware globally
	//r.Use(OptionsMiddleware())
	r.GET("/rtStatus", rtStatus)
	r.POST("/offlineTable", tableHandlerOffline)
	r.POST("/get", getter)
	r.POST("/rtTable", tableHandlerRT)

	// Use NoRoute to serve static files to avoid conflict with /rtStatus
	r.NoRoute(func(c *gin.Context) {
		path := c.Request.URL.Path
		// Remove leading slash for checking in fs.FS
		name := strings.TrimPrefix(path, "/")
		if name == "" {
			name = "index.html"
		}

		// Try to open the file to check existence
		f, err := web.Open(name)
		if err != nil {
			// File not found -> serve index.html (SPA support)
			c.FileFromFS("/", http.FS(web))
			return
		}
		f.Close()

		// File found -> serve it
		c.FileFromFS(path, http.FS(web))
	})

	err := r.Run(":" + port)
	if err != nil {
		fmt.Println("Cannot listen on " + port)
		return
	}
	fmt.Println("Listening on port :", port)
}

// OptionsMiddleware handles HTTP OPTIONS requests for CORS preflight.
func OptionsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.Request.Method == http.MethodOptions {
			// Set CORS headers for preflight requests
			c.Header("Access-Control-Allow-Origin", "*") // Or specific origins
			c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization") // Add other headers as needed
			c.Header("Access-Control-Max-Age", "86400")                             // Cache preflight response for 24 hours

			c.AbortWithStatus(http.StatusOK) // Abort and return 200 OK
			return
		}
		c.Next() // Continue to the next middleware or handler for other methods
	}
}

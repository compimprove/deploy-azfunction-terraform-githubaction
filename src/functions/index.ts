import { app, HttpResponseInit } from "@azure/functions";

app.http("index", {
  methods: ["GET", "POST"],
  authLevel: "anonymous",
  handler: async (): Promise<HttpResponseInit> => {
    return {
      status: 200,
      headers: {
        "Content-Type": "text/html",
      },
      body: "Hello World",
    };
  },
});

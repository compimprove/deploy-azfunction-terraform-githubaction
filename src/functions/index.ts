import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { readFile } from "fs/promises";

app.http("index", {
  methods: ["GET", "POST"],
  authLevel: "anonymous",
  handler: async (context: HttpRequest, invocationContext: InvocationContext): Promise<HttpResponseInit> => {
    let content: string;
    try {
      content = await readFile("index.html", "utf8");
    } catch (err) {
      console.error(err);
      return {
        status: 500,
        body: "Internal Server Error"
      };
    }
    return {
      status: 200,
      headers: {
        "Content-Type": "text/html",
      },
      body: content,
    };
  },
});

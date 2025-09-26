import Fastify from "fastify";
const app = Fastify({ logger: true });

app.get("/health", async () => ({ ok: true }));

const port = Number(process.env.PORT ?? 3000);
app.listen({ port, host: "0.0.0.0" });

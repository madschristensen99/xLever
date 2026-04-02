"""Combined runner for API server + Trading Agent."""

import asyncio
import os
import uvicorn
from loguru import logger

from agent.config import get_settings
from agent.main import TradingAgent
from agent.api.server import create_app, set_agent_instance
from agent.api.routes.agent import set_agent


async def run_combined():
    """Run API server and trading agent together."""
    settings = get_settings()

    # Get port from environment (Railway sets this)
    port = int(os.environ.get("PORT", 8080))

    # Create agent
    logger.info("Creating trading agent...")
    agent = TradingAgent(settings=settings, paper_mode=True)

    # Register agent with API
    set_agent_instance(agent)
    set_agent(agent)

    # Initialize agent
    await agent.initialize()
    logger.success("Trading agent initialized")

    # Create API app
    app = create_app()

    # Configure uvicorn
    config = uvicorn.Config(
        app=app,
        host="0.0.0.0",
        port=port,
        log_level="info",
    )
    server = uvicorn.Server(config)

    # Run both concurrently
    logger.info(f"Starting API server on port {port}...")
    logger.info("Starting trading agent loop...")

    await asyncio.gather(
        server.serve(),
        agent.run(),
    )


def main():
    """Entry point."""
    asyncio.run(run_combined())


if __name__ == "__main__":
    main()

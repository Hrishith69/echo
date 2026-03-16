"""Load environment configuration using dotenv."""

from dotenv import load_dotenv
import os

# Load environment variables from .env file in the project root
load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

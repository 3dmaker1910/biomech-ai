import os


class AIService:
    """
    Placeholder for AI integration.
    Will use Emergent LLM API: https://integrations.emergentagent.com/llm
    API key read from env: EMERGENT_LLM_KEY
    """

    def __init__(self):
        self.api_key = os.getenv("EMERGENT_LLM_KEY")
        self.base_url = "https://integrations.emergentagent.com/llm"

    async def analyze_footprint(self, image_path: str) -> dict:
        return {"status": "not_implemented", "version": "0.1"}

    async def generate_orthotic_image(self, orthotic_data: dict) -> str:
        return {"status": "not_implemented", "version": "0.1"}

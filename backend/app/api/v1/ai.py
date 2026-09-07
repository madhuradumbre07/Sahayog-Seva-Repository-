from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from app.services.ai_problem_parser import AiProblemParserService, ProblemParseResult

router = APIRouter(prefix="/ai", tags=["AI & Problem Parsing"])

class ParseProblemRequest(BaseModel):
    problem_text: str
    language_code: Optional[str] = "mr"
    media_attached: Optional[bool] = False

@router.post("/parse-problem", response_model=ProblemParseResult)
async def parse_problem(req: ParseProblemRequest):
    return AiProblemParserService.parse_problem(
        text=req.problem_text,
        detected_lang=req.language_code or "mr"
    )

return {
    provider = "gemini",
    mode = "agentic",
    auto_suggestions_provider = "gemini",
    
    providers = {
      gemini = {
        model = "gemini-2.5-pro", 
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 4096,
        },
      },
    },
    behaviour = {
      auto_suggestions = false, 
    },
}

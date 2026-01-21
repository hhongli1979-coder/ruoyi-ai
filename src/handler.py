#!/usr/bin/env python3
"""
RunPod Serverless Handler for RuoYi AI
This handler processes incoming requests from RunPod and forwards them to the Spring Boot application.
"""

import os
import sys
import json
import time
import logging
import requests
from typing import Dict, Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Configuration
SERVER_PORT = os.environ.get('SERVER_PORT', '8080')
BASE_URL = f"http://localhost:{SERVER_PORT}"
HEALTH_CHECK_URL = f"{BASE_URL}/actuator/health"
API_BASE_URL = f"{BASE_URL}/api"

# Timeout settings
REQUEST_TIMEOUT = 30  # seconds
MAX_RETRIES = 3


class RuoYiAIHandler:
    """Handler class for processing RunPod requests"""
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def wait_for_service(self, max_wait: int = 60) -> bool:
        """
        Wait for the Spring Boot service to become available
        
        Args:
            max_wait: Maximum time to wait in seconds
            
        Returns:
            True if service is available, False otherwise
        """
        logger.info(f"Waiting for service to be ready at {HEALTH_CHECK_URL}...")
        
        for i in range(max_wait):
            try:
                response = self.session.get(HEALTH_CHECK_URL, timeout=5)
                if response.status_code == 200:
                    logger.info("Service is ready!")
                    return True
            except requests.exceptions.RequestException as e:
                logger.debug(f"Service not ready yet (attempt {i+1}/{max_wait}): {str(e)}")
            
            time.sleep(1)
        
        logger.error("Service failed to start within timeout period")
        return False
    
    def health_check(self) -> Dict[str, Any]:
        """
        Perform health check on the application
        
        Returns:
            Health status dictionary
        """
        try:
            response = self.session.get(HEALTH_CHECK_URL, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "status": "healthy",
                    "application": "RuoYi AI",
                    "details": data
                }
            else:
                return {
                    "status": "unhealthy",
                    "error": f"Health check returned status code: {response.status_code}"
                }
        except Exception as e:
            logger.error(f"Health check failed: {str(e)}")
            return {
                "status": "unhealthy",
                "error": str(e)
            }
    
    def get_status(self) -> Dict[str, Any]:
        """
        Get service status
        
        Returns:
            Status dictionary
        """
        health = self.health_check()
        return {
            "status": "running" if health["status"] == "healthy" else "error",
            "health": health,
            "server_url": BASE_URL,
            "timestamp": time.time()
        }
    
    def chat(self, message: str, **kwargs) -> Dict[str, Any]:
        """
        Send a chat message to the AI assistant
        
        Args:
            message: The chat message
            **kwargs: Additional parameters
            
        Returns:
            Chat response dictionary
        """
        try:
            # Construct the chat API endpoint
            # Note: Adjust this endpoint based on your actual API structure
            chat_url = f"{API_BASE_URL}/chat"
            
            payload = {
                "message": message,
                **kwargs
            }
            
            logger.info(f"Sending chat request to {chat_url}")
            
            response = self.session.post(
                chat_url,
                json=payload,
                timeout=REQUEST_TIMEOUT
            )
            
            if response.status_code == 200:
                return {
                    "success": True,
                    "data": response.json()
                }
            else:
                return {
                    "success": False,
                    "error": f"Chat API returned status code: {response.status_code}",
                    "details": response.text
                }
                
        except requests.exceptions.Timeout:
            logger.error("Chat request timed out")
            return {
                "success": False,
                "error": "Request timed out"
            }
        except Exception as e:
            logger.error(f"Chat request failed: {str(e)}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def process_request(self, job: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process incoming RunPod job request
        
        Args:
            job: The job dictionary from RunPod
            
        Returns:
            Result dictionary
        """
        try:
            # Extract input from job
            job_input = job.get("input", {})
            action = job_input.get("action", "")
            
            logger.info(f"Processing action: {action}")
            
            # Route to appropriate handler
            if action == "health_check":
                return self.health_check()
            
            elif action == "status":
                return self.get_status()
            
            elif action == "chat":
                message = job_input.get("message", "")
                if not message:
                    return {
                        "error": "Message is required for chat action"
                    }
                
                # Extract additional parameters
                params = {k: v for k, v in job_input.items() if k not in ["action", "message"]}
                return self.chat(message, **params)
            
            else:
                return {
                    "error": f"Unknown action: {action}",
                    "supported_actions": ["health_check", "status", "chat"]
                }
                
        except Exception as e:
            logger.error(f"Error processing request: {str(e)}", exc_info=True)
            return {
                "error": str(e)
            }


def handler(job: Dict[str, Any]) -> Dict[str, Any]:
    """
    Main handler function for RunPod Serverless
    
    Args:
        job: The job dictionary from RunPod
        
    Returns:
        Result dictionary
    """
    logger.info(f"Received job: {json.dumps(job, indent=2)}")
    
    # Initialize handler
    handler_instance = RuoYiAIHandler()
    
    # Wait for service to be ready (only on first request)
    if not hasattr(handler, '_service_ready'):
        if not handler_instance.wait_for_service():
            return {
                "error": "Service failed to start",
                "status": "error"
            }
        handler._service_ready = True
    
    # Process the request
    result = handler_instance.process_request(job)
    
    logger.info(f"Returning result: {json.dumps(result, indent=2)}")
    return result


if __name__ == "__main__":
    """
    Entry point for the handler
    Can be run standalone for testing or integrated with RunPod
    """
    try:
        # Try to import runpod
        import runpod
        
        logger.info("Starting RunPod serverless handler...")
        logger.info(f"Server URL: {BASE_URL}")
        logger.info(f"Health check URL: {HEALTH_CHECK_URL}")
        
        # Start the RunPod serverless handler
        runpod.serverless.start({"handler": handler})
        
    except ImportError:
        # If runpod is not available, run a simple test
        logger.warning("runpod module not found, running in test mode")
        
        # Create test handler
        test_handler = RuoYiAIHandler()
        
        # Wait for service
        if test_handler.wait_for_service():
            # Run test requests
            test_jobs = [
                {"input": {"action": "health_check"}},
                {"input": {"action": "status"}},
            ]
            
            for test_job in test_jobs:
                logger.info(f"\nTesting with job: {json.dumps(test_job, indent=2)}")
                result = handler(test_job)
                logger.info(f"Result: {json.dumps(result, indent=2)}")
        else:
            logger.error("Service is not available")
            sys.exit(1)

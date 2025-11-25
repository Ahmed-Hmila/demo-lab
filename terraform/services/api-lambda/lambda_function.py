# terraform/services/api-lambda/lambda_function.py

import json

def lambda_handler(event, context):
    """
    Gestionnaire de la fonction Lambda.
    """
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': 'hello from lamda et api getway'
        })
    }

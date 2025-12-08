# terraform/services/api-lambda/lambda_function.py

def lambda_handler(event, context):
    """
    Gestionnaire de la fonction Lambda.
    L'ALB attend une réponse simple (non-proxy) ou une réponse formatée pour ALB.
    Ici, nous renvoyons une réponse simple pour l'ALB.
    """
    return {
        'statusCode': 200,
        'statusDescription': '200 OK',
        'isBase64Encoded': False,
        'headers': {
            'Content-Type': 'text/html'
        },
        'body': '<h1>hello from lamda et alb</h1>'
    }

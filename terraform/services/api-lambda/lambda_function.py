# terraform/services/api-lambda/lambda_function.py

def lambda_handler(event, context):
 
    return {
        'statusCode': 200,
        'statusDescription': '200 OK',
        'isBase64Encoded': False,
        'headers': {
            'Content-Type': 'text/html'
        },
        'body': '<h1>hello from lamda et alb</h1>'
    }

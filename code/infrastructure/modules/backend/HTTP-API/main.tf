resource "aws_apigatewayv2_api" "http_api" {
  name = "http-api"
  protocol_type = "HTTP"
  description = "Recipe Sharing Applicatoin - Serverless API"
  cors_configuration {
    allow_origins = [ "*" ]
    allow_methods = [ "GET", "POST", "PUT", "DELETE" ]
    allow_headers = [ "*" ]
  }
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name = var.stage_name
  auto_deploy = true
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id                            = aws_apigatewayv2_api.http_api.id
  name                              = "CognitoAuthorizer"
  authorizer_type                   = "JWT"
  identity_sources                  = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"

  jwt_configuration {
    audience = var.pool_client
    issuer = var.cognito_pool_user_endpoint
  }
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id = aws_apigatewayv2_api.http_api.id

  route_key = "GET /auth"

}

resource "aws_apigatewayv2_integration" "auth_api_lambda_integration" {
  api_id = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  integration_uri = var.lambda_auth_invoke_arn
  payload_format_version = "2.0"
  
}
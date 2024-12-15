# Static Website with AWS Lambda

This project is a static website hosted on AWS S3 that interacts with an AWS Lambda function to fetch and display text data.

## Project Structure

```
static-website
├── src
│   ├── index.html       # Main HTML document for the static website
│   ├── app.js           # JavaScript code to fetch data from Lambda
│   └── styles.css       # CSS styles for the website
├── lambda
│   ├── handler.js       # AWS Lambda function code
│   └── package.json     # Configuration file for Lambda dependencies
├── terraform
│   ├── main.tf          # Main Terraform configuration
│   ├── variables.tf     # Input variables for Terraform
│   ├── outputs.tf       # Outputs of the Terraform configuration
│   └── provider.tf      # AWS provider configuration for Terraform
├── .gitignore           # Files and directories to ignore by Git
└── README.md            # Project documentation
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd static-website
   ```

2. **Deploy the Lambda function:**
   Navigate to the `lambda` directory and install dependencies:
   ```
   cd lambda
   npm install
   ```

3. **Deploy the infrastructure using Terraform:**
   Navigate to the `terraform` directory and initialize Terraform:
   ```
   cd ../terraform
   terraform init
   terraform apply
   ```

4. **Access the static website:**
   After deployment, you will receive the URL of the S3 bucket where the static website is hosted. Open this URL in your web browser to view the website.

## Usage

The static website will call the AWS Lambda function to retrieve text data and display it in the UI. Ensure that the Lambda function is properly configured to handle requests from the website.

## License

This project is licensed under the MIT License.
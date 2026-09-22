import json
import os
import boto3

table = boto3.resource("dynamodb").Table(
    os.environ["EMPLOYEE_TABLE"]
)


def lambda_handler(event, context):
    employee_id = event.get("pathParameters", {}).get("id")

    if not employee_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Employee ID is required"})
        }

    result = table.get_item(
        Key={"EmployeeID": employee_id}
    )

    employee = result.get("Item")

    if not employee:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Employee not found"})
        }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "employeeId": employee["EmployeeID"],
            "name": employee["Name"],
            "salary": int(employee["Salary"]),
            "dateOfJoin": employee["DateOfJoin"],
            "description": employee["Description"]
        })
    }
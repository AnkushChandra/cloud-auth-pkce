export const handler = async () => {
  const cognitoDomain = process.env.COGNITO_DOMAIN;
  const cognitoClientId = process.env.COGNITO_CLIENT_ID;

  if (!cognitoDomain || !cognitoClientId) {
      return {
          statusCode: 500,
          body: "Missing Cognito environment variables"
      };
  }

  const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Employee Search</title>

  <style>
      body {
          font-family: Arial, sans-serif;
          max-width: 600px;
          margin: 60px auto;
      }

      input, button {
          padding: 10px;
          margin: 5px;
      }

      #result {
          margin-top: 20px;
          white-space: pre-line;
      }
  </style>
</head>

<body>
  <h1>Employee Search</h1>

  <button id="loginButton" onclick="login()">Sign in</button>

  <form id="searchForm" onsubmit="searchEmployee(event)" hidden>
      <input id="employeeId" placeholder="Employee ID" required>
      <button type="submit">Search</button>
  </form>

  <div id="result"></div>

  <script>
      const cognitoDomain = ${JSON.stringify(cognitoDomain)};
      const clientId = ${JSON.stringify(cognitoClientId)};

      const redirectUri =
          window.location.origin + window.location.pathname;

      const apiUrl = redirectUri.replace(/\\/$/, "");

      function encode(bytes) {
          return btoa(
              String.fromCharCode(...new Uint8Array(bytes))
          )
          .replace(/\\+/g, "-")
          .replace(/\\//g, "_")
          .replace(/=+$/, "");
      }

      async function login() {
          const random = crypto.getRandomValues(
              new Uint8Array(32)
          );

          const verifier = encode(random);

          const hash = await crypto.subtle.digest(
              "SHA-256",
              new TextEncoder().encode(verifier)
          );

          const challenge = encode(hash);

          sessionStorage.setItem("verifier", verifier);

          const parameters = new URLSearchParams({
              response_type: "code",
              client_id: clientId,
              redirect_uri: redirectUri,
              scope: "openid email profile",
              code_challenge: challenge,
              code_challenge_method: "S256"
          });

          window.location =
              cognitoDomain + "/oauth2/authorize?" + parameters;
      }

      async function handleLogin() {
          const parameters = new URLSearchParams(
              window.location.search
          );

          const code = parameters.get("code");

          if (code) {
              const body = new URLSearchParams({
                  grant_type: "authorization_code",
                  client_id: clientId,
                  redirect_uri: redirectUri,
                  code: code,
                  code_verifier:
                      sessionStorage.getItem("verifier")
              });

              const response = await fetch(
                  cognitoDomain + "/oauth2/token",
                  {
                      method: "POST",
                      headers: {
                          "Content-Type":
                              "application/x-www-form-urlencoded"
                      },
                      body: body
                  }
              );

              const tokens = await response.json();

              if (tokens.id_token) {
                  sessionStorage.setItem(
                      "id_token",
                      tokens.id_token
                  );

                  history.replaceState({}, "", redirectUri);
              }
          }

          const loggedIn =
              sessionStorage.getItem("id_token") !== null;

          document.getElementById("loginButton").hidden =
              loggedIn;

          document.getElementById("searchForm").hidden =
              !loggedIn;
      }

      async function searchEmployee(event) {
          event.preventDefault();

          const employeeId =
              document.getElementById("employeeId").value;

          const response = await fetch(
              apiUrl + "/employee/" +
              encodeURIComponent(employeeId),
              {
                  headers: {
                      Authorization:
                          "Bearer " +
                          sessionStorage.getItem("id_token")
                  }
              }
          );

          const employee = await response.json();
          const result = document.getElementById("result");

          if (!response.ok) {
              result.textContent =
                  employee.message || "Employee not found";
              return;
          }

          result.textContent =
              "Employee ID: " + employee.employeeId + "\\n" +
              "Name: " + employee.name + "\\n" +
              "Salary: $" + employee.salary + "\\n" +
              "Date of Join: " + employee.dateOfJoin + "\\n" +
              "Description: " + employee.description;
      }

      handleLogin();
  </script>
</body>
</html>
`;

  return {
      statusCode: 200,
      headers: {
          "Content-Type": "text/html"
      },
      body: html
  };
};
import { writeFile } from "node:fs/promises";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const downloadUrl =
  "https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/_next/static/chunks/3711.88eee830d1c25cc8.js";

// Download aws js sdk JS
const response = await fetch(downloadUrl);
let body = await response.text();
body = body.replace(/^.*JSON.parse\('/, "").replace(/'\).*$/, "");

const awsSdk = JSON.parse(body);

// Map of package ID => package name
const packageMap = {};
Object.keys(awsSdk.packageMap).forEach((key) => (packageMap[awsSdk.packageMap[key]] = key));
writeFile(__dirname + "/aws-sdk-package-map.json", JSON.stringify(packageMap));

const final = [];
awsSdk.routes.forEach((route) => {
  // [1, "C", "AccessAnalyzer"],
  final.push(`${route[2]}|${awsSdk.typeMap[route[1]]}|${route[0]}`);
});

writeFile(__dirname + "/aws-sdk-js.txt", final.join("\n"));

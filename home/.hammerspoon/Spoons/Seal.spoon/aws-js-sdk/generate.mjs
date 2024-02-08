import { writeFile } from "node:fs/promises";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const docsUrl = "https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/";
let response = await fetch(docsUrl);
let body = await response.text();

// src="/AWSJavaScriptSDK/v3/latest/_next/static/chunks/webpack-056504c57a44ca2b.js"
const webpackUrl =
  "https://docs.aws.amazon.com" +
  body.match(/src="(\/AWSJavaScriptSDK\/v3\/latest\/_next\/static\/chunks\/webpack-.*?)"/)[1];
response = await fetch(webpackUrl);
body = await response.text();

const a = body.match(/3711:"(.*?)"/);

// "."+{3711:"a8380bcb31962806",4281:"a7acee2....
// We need "3711".
const downloadUrl = `https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/_next/static/chunks/3711.${body.match(/3711:"(.*?)"/)[1]}.js`;

console.log("Generating searchindex from " + downloadUrl);

// Download aws js sdk JS
response = await fetch(downloadUrl);
body = await response.text();
body = body.replace(/^.*JSON.parse\('/, "").replace(/'\).*$/, "");

const awsSdk = JSON.parse(body);

// Map of package ID => package name
const packageMap = {};
Object.keys(awsSdk.packageMap).forEach((key) => (packageMap[awsSdk.packageMap[key]] = key));
writeFile(__dirname + "/aws-sdk-package-map.json", JSON.stringify(packageMap));

const final = [];
awsSdk.routes.forEach((route) => {
  // lib-storage|Options|Interface|412
  final.push(`${packageMap[route[0]].replace("aws-sdk-", "")}|${route[2]}|${awsSdk.typeMap[route[1]]}|${route[0]}`);
});

writeFile(__dirname + "/aws-sdk-js.txt", final.join("\n"));

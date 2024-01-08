import { TranslateClient, TranslateTextCommand } from "@aws-sdk/client-translate";

export const translate = async event => {
  const client = new TranslateClient({ region: "eu-central-1" });

  const params = {
    SourceLanguageCode: event.queryStringParameters.sourceLanguage || "auto",
    TargetLanguageCode: event.queryStringParameters.targetLanguage || process.env.DEFAULT_TARGET_LANGUAGE,
    Text: event.queryStringParameters.text || "",
  };

  if (params.Text.length < 1) {
    return {
      statusCode: 400,
    };
  }

  const command = new TranslateTextCommand(params);
  const response = await client.send(command);

  return {
    statusCode: response.$metadata.httpStatusCode,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      source: response.SourceLanguageCode,
      target: response.TargetLanguageCode,
      text: response.TranslatedText,
    }),
    isBase64Encoded: false,
  };
};

if (process.env.TESTING) {
  const response = await translate({
    queryStringParameters: {
      text: "Hoe kwam het Stuxnet-virus in 2007 in het hermetisch afgesloten Iraanse nucleaire complex in Natanz?",
      sourceLanguage: "auto",
      targetLanguage: "de",
    },
  });

  console.log(response);
}

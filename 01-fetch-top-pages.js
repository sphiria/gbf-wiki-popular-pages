#!/usr/bin/env node

const main = async () => {
  const url = 'https://api.cloudflare.com/client/v4/graphql'
  const headers = {
    "Authorization": `Bearer ${process.env.CLOUDFLARE_TOKEN}`,
  };

  // We need to query with 1 week window
  const date = new Date();
  date.setDate(date.getDate() - 7);
  const lastWeekDate = date.toISOString().substring(0, 10);

  // Build graphql query
  const query = `
  {
    viewer {
      zones(filter: {zoneTag: "${process.env.CLOUDFLARE_ZONE_ID}"}) {
        httpRequestsAdaptiveGroups(
          filter: {
            date_gt: "${lastWeekDate}",
            edgeResponseContentTypeName: "html"
            AND: [
              { clientRequestPath_notlike: "%.php" },
              { clientRequestPath_notlike: "/Special:%" },
              { clientRequestPath_notlike: "/cdn-cgi/%" },
              { clientRequestPath_notin: [
                "/"
                "/Main_Page",
                "/Character_Tier_List"
              ]}
            ]
          }
          orderBy: [ sum_visits_DESC ]
          limit: 10
        ) {
          dimensions {
            clientRequestPath
          }
        }
      }
    }
  }
  `;

  // Send request
  const resp = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify({ query }),
  });

  // Print pages
  const json = await resp.json();
  json.data.viewer.zones[0].httpRequestsAdaptiveGroups
    .map(result => result.dimensions.clientRequestPath)
    .map(string => string.replace(/^\//, ""))
    .map(string => string.replace(/_/g, " "))
    .map(page => `# [[${page}]]`)
    .forEach(entry => console.log(entry));
}

main();

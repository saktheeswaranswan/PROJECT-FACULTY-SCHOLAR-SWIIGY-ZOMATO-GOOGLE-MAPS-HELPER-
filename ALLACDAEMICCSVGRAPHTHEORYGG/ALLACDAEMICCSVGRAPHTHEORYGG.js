let apiUrl = "https://overpass-api.de/api/interpreter";
let query = `
[out:json];
area["name"="Madurai"]->.searchArea;
(
  node["highway"](area.searchArea);
  node["amenity"](area.searchArea);
  node["shop"](area.searchArea);
  node["school"](area.searchArea);
  node["hospital"](area.searchArea);
  node["park"](area.searchArea);
  node["fuel"](area.searchArea);
);
out body;
>;
out skel qt;
`;

let nodes = [];

function setup() {
  createCanvas(800, 600);
  fetchData();
}

function fetchData() {
  let params = {
    method: 'POST',
    body: `data=${encodeURIComponent(query)}`
  };

  fetch(apiUrl, params)
    .then(response => response.json())
    .then(data => {
      nodes = data.elements; // store the fetched nodes
      console.log(nodes); // logging fetched nodes to console for debugging

      // Once data is fetched, you can process the nodes, e.g., save CSV or visualize them
      processNodes(nodes);
    })
    .catch(error => console.error('Error fetching data:', error));
}

function processNodes(nodes) {
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];
    if (node.lat && node.lon) {
      // Example: Drawing nodes on the canvas as points
      let x = map(node.lon, 78.0, 78.1, 0, width);  // Longitude to x-coordinate
      let y = map(node.lat, 9.9, 10.0, height, 0); // Latitude to y-coordinate
      ellipse(x, y, 5, 5); // Draw each node as a circle
    }
  }
}

const maduraiBbox = {
  north: 9.9833,
  south: 9.8833,
  west: 78.0833,
  east: 78.1833
};

const numPoints = 500;
let randomCoords = [];

function setup() {
  createCanvas(400, 400);
  noLoop(); // No need to continuously redraw

  // Generate random coordinates within the bounding box
  for (let i = 0; i < numPoints; i++) {
    let lat = random(maduraiBbox.south, maduraiBbox.north);
    let lon = random(maduraiBbox.west, maduraiBbox.east);
    randomCoords.push({ lat: lat, lon: lon });
  }

  // Generate the all-in-one Google Maps URL
  displayLinks();
}

function displayLinks() {
  // Create a div to hold the links
  let linkContainer = createDiv();
  linkContainer.position(10, 10);

  // Initialize an empty array to store the locations for the Google Maps link
  let allCoordinates = [];

  // Prepare all the coordinates in a single string
  for (let i = 0; i < randomCoords.length; i++) {
    let lat = randomCoords[i].lat.toFixed(6);
    let lon = randomCoords[i].lon.toFixed(6);
    allCoordinates.push(`${lat},${lon}`);
  }

  // Create the full Google Maps link with all the coordinates
  let allCoordsString = allCoordinates.join('|'); // Coordinates separated by "|"
  let gmapLink = `https://www.google.com/maps/dir/?api=1&waypoints=${allCoordsString}`;

  // Create a clickable link for all coordinates
  let link = createA(gmapLink, `View all ${numPoints} Locations on Google Maps`);
  link.parent(linkContainer);
  link.style('display', 'block'); // Display the link
}

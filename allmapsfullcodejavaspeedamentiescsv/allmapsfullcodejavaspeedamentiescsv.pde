import java.net.*;
import java.io.*;
import processing.data.JSONArray;
import processing.data.JSONObject;

String[] locations = new String[0];
String overpassUrl = "https://overpass-api.de/api/interpreter";
String query = "[out:json];" +
               "area['name'='India']->.searchArea;" +
               "node['amenity'='fuel'](area.searchArea);" +
               "node['amenity'='hospital'](area.searchArea);" +
               "node['amenity'='school'](area.searchArea);" +
               "node['amenity'='toll_gate'](area.searchArea);" +
               "node['railway'='crossing'](area.searchArea);" +
               "node['highway'='speed_camera'](area.searchArea);" +  // Speed breakers
               "node['highway'='unclassified'](area.searchArea); " + // Potholes (or similar)
               "out body; >; out skel qt;";

void setup() {
  size(800, 800);  // Set the size of the canvas
  background(255);

  // Send the HTTP POST request to the Overpass API
  String response = sendPostRequest(overpassUrl, query);
  if (response != null) {
    // Parse the JSON response using Processing's JSONObject
    JSONObject jsonResponse = parseJSONObject(response);
    if (jsonResponse != null && jsonResponse.hasKey("elements")) {
      JSONArray elements = jsonResponse.getJSONArray("elements");

      // Loop through elements and extract the data
      for (int i = 0; i < elements.size(); i++) {
        JSONObject element = elements.getJSONObject(i);
        if (element.hasKey("lat") && element.hasKey("lon")) {
          float lat = element.getFloat("lat");
          float lon = element.getFloat("lon");

          // Prepare the CSV data
          String amenityType = element.hasKey("amenity") ? element.getString("amenity") : 
                               (element.hasKey("railway") ? element.getString("railway") : 
                               (element.hasKey("highway") ? element.getString("highway") : "Unknown"));
          String googleMapsLink = "https://www.google.com/maps?q=" + lat + "," + lon;
          locations = append(locations, amenityType + "," + lat + "," + lon + "," + googleMapsLink);
        }
      }

      // Save the data as a CSV if locations exist
      if (locations.length > 0) {
        saveCSV("amenities_india.csv", locations);
        textSize(16);
        fill(0);
        text("CSV file with amenities saved!", width / 2, height / 2);
      } else {
        textSize(16);
        fill(255, 0, 0);
        text("No amenities found for India.", width / 2, height / 2);
      }

      // Draw the closed graph with points connected
      drawGraph();
    } else {
      textSize(16);
      fill(255, 0, 0);
      text("Error parsing response or no elements found.", width / 2, height / 2);
    }
  } else {
    textSize(16);
    fill(255, 0, 0);
    text("Failed to fetch data from Overpass API.", width / 2, height / 2);
  }
}

void draw() {
  // No drawing needed here as we already handled the drawing in setup
}

String sendPostRequest(String url, String data) {
  try {
    // Set up the connection
    URL obj = new URL(url);
    HttpURLConnection con = (HttpURLConnection) obj.openConnection();
    con.setRequestMethod("POST");
    con.setDoOutput(true);
    con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

    // Send the POST data
    try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
      wr.writeBytes("data=" + URLEncoder.encode(data, "UTF-8"));
      wr.flush();
    }

    // Get the response code
    int responseCode = con.getResponseCode();
    if (responseCode == HttpURLConnection.HTTP_OK) {
      // Read the response
      BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
      String inputLine;
      StringBuffer response = new StringBuffer();

      while ((inputLine = in.readLine()) != null) {
        response.append(inputLine);
      }
      in.close();

      return response.toString();
    } else {
      println("POST request failed. Response Code: " + responseCode);
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
  return null;
}

void saveCSV(String filename, String[] data) {
  String header = "Amenity Type,Latitude,Longitude,Google Maps Link\n";
  String content = header + join(data, "\n");

  // Save the content as a CSV file
  saveStrings(filename, split(content, "\n"));
}

void drawGraph() {
  // Iterate over all points and draw them
  stroke(0, 100, 255);
  fill(0, 100, 255, 150);
  
  // Draw points and connect them
  for (int i = 0; i < locations.length; i++) {
    String[] parts = split(locations[i], ",");
    float lat = Float.parseFloat(parts[1]);
    float lon = Float.parseFloat(parts[2]);
    
    float x = map(lon, -180, 180, 0, width);
    float y = map(lat, -90, 90, height, 0);
    
    ellipse(x, y, 10, 10);  // Draw a small circle for each point
    if (i > 0) {
      String[] prevParts = split(locations[i - 1], ",");
      float prevLat = Float.parseFloat(prevParts[1]);
      float prevLon = Float.parseFloat(prevParts[2]);
      
      line(map(prevLon, -180, 180, 0, width), 
           map(prevLat, -90, 90, height, 0),
           x, y);
    }
  }
  
  // Connect the last point to the first to close the loop
  if (locations.length > 1) {
    String[] firstParts = split(locations[0], ",");
    float firstLat = Float.parseFloat(firstParts[1]);
    float firstLon = Float.parseFloat(firstParts[2]);

    line(map(Float.parseFloat(parts[2]), -180, 180, 0, width), 
         map(Float.parseFloat(parts[1]), -90, 90, height, 0),
         map(firstLon, -180, 180, 0, width), 
         map(firstLat, -90, 90, height, 0));
  }

  // Save the canvas as a PNG
  save("connected_points_graph.png");
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.mozixx.controller;

import com.mycompany.mozixx.model.Movies;
import com.mycompany.mozixx.service.MovieService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.json.Json;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.json.JSONArray;
import org.json.JSONObject;

@Path("/movies")
public class MovieController {
    private MovieService movieService = new MovieService();
    
    @GET
@Path("/all")
@Produces(MediaType.APPLICATION_JSON)
public Response getMoviesWithDetails() {
    try {
        JSONArray movies = movieService.getMoviesWithDetails();
        
        JSONObject response = new JSONObject();
        response.put("status", "success");
        response.put("count", movies.length());
        response.put("movies", movies);
        
        return Response.ok(response.toString()).build();
    } catch (Exception e) {
        JSONObject error = new JSONObject();
        error.put("status", "error");
        error.put("message", "Failed to fetch movies");
        error.put("details", e.getMessage());
        
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                     .entity(error.toString())
                     .build();
    }
}
    @GET
@Path("/random")
@Produces(MediaType.APPLICATION_JSON)
public Response getRandomMovies() {
    try {
        JSONArray randomMovies = movieService.getRandomMovies(4);
        
        // Átlag értékelés kiszámolása az összes visszaadott filmre
        double overallAverage = calculateOverallAverage(randomMovies);
        
        JSONObject response = new JSONObject();
        response.put("status", "success");
        response.put("count", randomMovies.length());
        response.put("overallAverageRating", overallAverage);
        response.put("movies", randomMovies);
        
        return Response.ok(response.toString()).build();
        
    } catch (Exception e) {
        JSONObject error = new JSONObject();
        error.put("status", "error");
        error.put("message", "Nem sikerült lekérni a filmeket");
        error.put("details", e.getMessage());
        return Response
            .status(Response.Status.INTERNAL_SERVER_ERROR)
            .entity(error.toString())
            .build();
    }
}

private double calculateOverallAverage(JSONArray movies) {
    if (movies.length() == 0) return 0.0;
    
    double sum = 0;
    int count = 0;
    
    for (int i = 0; i < movies.length(); i++) {
        JSONObject movie = movies.getJSONObject(i);
        double rating = movie.getDouble("averageRating");
        if (rating > 0) {
            sum += rating;
            count++;
        }
    }
    
    return count > 0 ? Math.round((sum / count) * 10) / 10.0 : 0.0;
}
    
    @GET
@Path("/latest")
@Produces(MediaType.APPLICATION_JSON)
public Response getLatestReleases() {
    try {
        List<Map<String, Object>> movies = movieService.getLatestReleases();
        return Response.ok(movies).build();
    } catch (Exception e) {
        Map<String, String> error = new HashMap<>();
        error.put("error", e.getMessage());
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                     .entity(error)
                     .build();
    }
}
    
    @GET
    @Path("/search")
    @Produces(MediaType.APPLICATION_JSON)
    public Response searchMoviesByName(@QueryParam("q") String searchTerm) {
        try {
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                JSONObject error = new JSONObject();
                error.put("status", "error");
                error.put("message", "Keresési kifejezés megadása kötelező");
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(error.toString())
                        .build();
            }

            JSONArray movies = movieService.searchMoviesByName(searchTerm);

            JSONObject response = new JSONObject();
            response.put("status", "success");
            response.put("searchTerm", searchTerm);
            response.put("count", movies.length());
            response.put("movies", movies);

            return Response.ok(response.toString()).build();

        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("status", "error");
            error.put("message", "Hiba történt a filmek keresése közben");
            error.put("details", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(error.toString())
                    .build();
        }
    }
@GET
@Path("/{id}")
@Produces(MediaType.APPLICATION_JSON)
public Response getMovieById(@PathParam("id") int movieId) {
    try {
        JSONObject movie = movieService.getMovieById(movieId);
        
        if (movie == null) {
            JSONObject error = new JSONObject();
            error.put("status", "error");
            error.put("message", "Film nem található");
            return Response.status(Response.Status.NOT_FOUND)
                         .entity(error.toString())
                         .build();
        }
        
        JSONObject response = new JSONObject();
        response.put("status", "success");
        response.put("movie", movie);
        
        return Response.ok(response.toString()).build();
        
    } catch (Exception e) {
        JSONObject error = new JSONObject();
        error.put("status", "error");
        error.put("message", "Hiba történt a film lekérdezése közben");
        error.put("details", e.getMessage());
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                     .entity(error.toString())
                     .build();
    }
}
}
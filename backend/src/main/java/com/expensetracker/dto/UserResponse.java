package com.expensetracker.dto;

public record UserResponse(String id, String name, String email, String profilePictureUrl, String currency) {
}

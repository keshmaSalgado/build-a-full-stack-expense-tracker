package com.expensetracker.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateUserRequest(
        @NotBlank String name,
        String profilePictureUrl,
        @NotBlank String currency
) {
}

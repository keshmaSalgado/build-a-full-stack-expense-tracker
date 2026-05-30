package com.expensetracker.dto;

import com.expensetracker.entity.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDate;

public record TransactionResponse(
        String id,
        String title,
        String description,
        BigDecimal amount,
        LocalDate date,
        TransactionType type,
        CategoryResponse category
) {
}

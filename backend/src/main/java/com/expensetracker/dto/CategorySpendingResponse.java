package com.expensetracker.dto;

import java.math.BigDecimal;

public record CategorySpendingResponse(String category, BigDecimal amount) {
}

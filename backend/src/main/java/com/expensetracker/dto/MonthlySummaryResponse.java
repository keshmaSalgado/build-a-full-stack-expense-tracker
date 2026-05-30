package com.expensetracker.dto;

import java.math.BigDecimal;

public record MonthlySummaryResponse(int month, int year, BigDecimal income, BigDecimal expense) {
}

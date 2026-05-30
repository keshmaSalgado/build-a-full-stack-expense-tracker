package com.expensetracker.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record IncomeExpenseResponse(LocalDate startDate, LocalDate endDate, BigDecimal income, BigDecimal expense) {
}

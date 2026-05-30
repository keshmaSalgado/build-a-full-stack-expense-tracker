package com.expensetracker.controller;

import com.expensetracker.dto.CategorySpendingResponse;
import com.expensetracker.dto.IncomeExpenseResponse;
import com.expensetracker.dto.MonthlySummaryResponse;
import com.expensetracker.dto.SummaryResponse;
import com.expensetracker.entity.User;
import com.expensetracker.service.ReportService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
public class ReportController {
    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/summary")
    public SummaryResponse summary(@AuthenticationPrincipal User user) {
        return reportService.summary(user);
    }

    @GetMapping("/monthly")
    public List<MonthlySummaryResponse> monthly(@AuthenticationPrincipal User user) {
        return reportService.monthly(user);
    }

    @GetMapping("/categories")
    public List<CategorySpendingResponse> categories(@AuthenticationPrincipal User user) {
        return reportService.categories(user);
    }

    @GetMapping("/income-vs-expense")
    public IncomeExpenseResponse incomeVsExpense(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return reportService.incomeVsExpense(user, startDate, endDate);
    }
}

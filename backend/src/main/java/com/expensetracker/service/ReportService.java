package com.expensetracker.service;

import com.expensetracker.dto.CategorySpendingResponse;
import com.expensetracker.dto.IncomeExpenseResponse;
import com.expensetracker.dto.MonthlySummaryResponse;
import com.expensetracker.dto.SummaryResponse;
import com.expensetracker.entity.Transaction;
import com.expensetracker.entity.TransactionType;
import com.expensetracker.entity.User;
import com.expensetracker.repository.CategoryRepository;
import com.expensetracker.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReportService {
    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;

    public ReportService(TransactionRepository transactionRepository, CategoryRepository categoryRepository) {
        this.transactionRepository = transactionRepository;
        this.categoryRepository = categoryRepository;
    }

    public SummaryResponse summary(User user) {
        List<Transaction> transactions = transactionRepository.findByUserId(user.getId());
        BigDecimal income = sumByType(transactions, TransactionType.INCOME);
        BigDecimal expense = sumByType(transactions, TransactionType.EXPENSE);
        return new SummaryResponse(income, expense, income.subtract(expense));
    }

    public List<MonthlySummaryResponse> monthly(User user) {
        Map<String, MonthlySummaryResponse> rows = new LinkedHashMap<>();
        transactionRepository.findByUserId(user.getId()).stream()
                .sorted((a, b) -> a.getDate().compareTo(b.getDate()))
                .forEach(transaction -> putMonthly(rows, transaction));
        return rows.values().stream().toList();
    }

    public List<CategorySpendingResponse> categories(User user) {
        Map<String, String> categoryNames = categoryRepository.findByUserIdOrderByNameAsc(user.getId()).stream()
                .collect(Collectors.toMap(category -> category.getId(), category -> category.getName()));
        return transactionRepository.findByUserId(user.getId()).stream()
                .filter(transaction -> transaction.getType() == TransactionType.EXPENSE)
                .collect(Collectors.groupingBy(
                        transaction -> categoryNames.getOrDefault(transaction.getCategoryId(), "Unknown"),
                        LinkedHashMap::new,
                        Collectors.reducing(BigDecimal.ZERO, Transaction::getAmount, BigDecimal::add)
                ))
                .entrySet()
                .stream()
                .map(entry -> new CategorySpendingResponse(entry.getKey(), entry.getValue()))
                .toList();
    }

    public IncomeExpenseResponse incomeVsExpense(User user, LocalDate startDate, LocalDate endDate) {
        LocalDate start = startDate == null ? YearMonth.now().atDay(1) : startDate;
        LocalDate end = endDate == null ? YearMonth.now().atEndOfMonth() : endDate;
        List<Transaction> transactions = transactionRepository.findByUserId(user.getId()).stream()
                .filter(transaction -> !transaction.getDate().isBefore(start) && !transaction.getDate().isAfter(end))
                .toList();
        BigDecimal income = sumByType(transactions, TransactionType.INCOME);
        BigDecimal expense = sumByType(transactions, TransactionType.EXPENSE);
        return new IncomeExpenseResponse(start, end, income, expense);
    }

    private BigDecimal sumByType(List<Transaction> transactions, TransactionType type) {
        return transactions.stream()
                .filter(transaction -> transaction.getType() == type)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private void putMonthly(Map<String, MonthlySummaryResponse> rows, Transaction transaction) {
        int month = transaction.getDate().getMonthValue();
        int year = transaction.getDate().getYear();
        BigDecimal amount = transaction.getAmount();
        String key = year + "-" + month;
        MonthlySummaryResponse existing = rows.getOrDefault(key, new MonthlySummaryResponse(month, year, BigDecimal.ZERO, BigDecimal.ZERO));
        rows.put(key, transaction.getType() == TransactionType.INCOME
                ? new MonthlySummaryResponse(month, year, existing.income().add(amount), existing.expense())
                : new MonthlySummaryResponse(month, year, existing.income(), existing.expense().add(amount)));
    }
}

package com.expensetracker.service;

import com.expensetracker.dto.TransactionRequest;
import com.expensetracker.dto.TransactionResponse;
import com.expensetracker.entity.Category;
import com.expensetracker.entity.Transaction;
import com.expensetracker.entity.TransactionType;
import com.expensetracker.entity.User;
import com.expensetracker.exception.ApiException;
import com.expensetracker.repository.TransactionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.regex.Pattern;

@Service
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final CategoryService categoryService;
    private final MapperService mapperService;
    private final MongoTemplate mongoTemplate;

    public TransactionService(TransactionRepository transactionRepository, CategoryService categoryService, MapperService mapperService, MongoTemplate mongoTemplate) {
        this.transactionRepository = transactionRepository;
        this.categoryService = categoryService;
        this.mapperService = mapperService;
        this.mongoTemplate = mongoTemplate;
    }

    public Page<TransactionResponse> findAll(User user, String search, String categoryId, YearMonth month,
                                             LocalDate startDate, LocalDate endDate, TransactionType type,
                                             Pageable pageable) {
        Query query = new Query().addCriteria(Criteria.where("userId").is(user.getId()));
        if (search != null && !search.isBlank()) {
            Pattern pattern = Pattern.compile(Pattern.quote(search), Pattern.CASE_INSENSITIVE);
            query.addCriteria(new Criteria().orOperator(
                    Criteria.where("title").regex(pattern),
                    Criteria.where("description").regex(pattern)
            ));
        }
        if (categoryId != null && !categoryId.isBlank()) {
            query.addCriteria(Criteria.where("categoryId").is(categoryId));
        }
        if (type != null) {
            query.addCriteria(Criteria.where("type").is(type));
        }
        LocalDate effectiveStart = startDate;
        LocalDate effectiveEnd = endDate;
        if (month != null) {
            effectiveStart = month.atDay(1);
            effectiveEnd = month.atEndOfMonth();
        }
        if (effectiveStart != null || effectiveEnd != null) {
            Criteria dateCriteria = Criteria.where("date");
            if (effectiveStart != null) {
                dateCriteria = dateCriteria.gte(effectiveStart);
            }
            if (effectiveEnd != null) {
                dateCriteria = dateCriteria.lte(effectiveEnd);
            }
            query.addCriteria(dateCriteria);
        }
        long total = mongoTemplate.count(query, Transaction.class);
        List<TransactionResponse> content = mongoTemplate.find(query.with(pageable), Transaction.class).stream()
                .map(mapperService::toTransactionResponse)
                .toList();
        return new PageImpl<>(content, pageable, total);
    }

    public TransactionResponse findById(User user, String id) {
        return mapperService.toTransactionResponse(getOwnedTransaction(user, id));
    }

    public TransactionResponse create(User user, TransactionRequest request) {
        Category category = categoryService.getOwnedCategory(user, request.categoryId());
        Transaction transaction = new Transaction(
                request.title(),
                request.description(),
                request.amount(),
                request.date(),
                request.type(),
                category.getId(),
                user.getId()
        );
        return mapperService.toTransactionResponse(transactionRepository.save(transaction));
    }

    public TransactionResponse update(User user, String id, TransactionRequest request) {
        Transaction transaction = getOwnedTransaction(user, id);
        Category category = categoryService.getOwnedCategory(user, request.categoryId());
        transaction.setTitle(request.title());
        transaction.setDescription(request.description());
        transaction.setAmount(request.amount());
        transaction.setDate(request.date());
        transaction.setType(request.type());
        transaction.setCategoryId(category.getId());
        return mapperService.toTransactionResponse(transactionRepository.save(transaction));
    }

    public void delete(User user, String id) {
        transactionRepository.delete(getOwnedTransaction(user, id));
    }

    private Transaction getOwnedTransaction(User user, String id) {
        return transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ApiException("Transaction not found", HttpStatus.NOT_FOUND));
    }
}

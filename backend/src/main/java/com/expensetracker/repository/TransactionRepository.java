package com.expensetracker.repository;

import com.expensetracker.entity.Transaction;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface TransactionRepository extends MongoRepository<Transaction, String> {
    Optional<Transaction> findByIdAndUserId(String id, String userId);
    List<Transaction> findByUserId(String userId);
}

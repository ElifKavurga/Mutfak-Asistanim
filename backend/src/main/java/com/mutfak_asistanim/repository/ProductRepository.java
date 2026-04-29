package com.mutfak_asistanim.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mutfak_asistanim.model.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
	
	
	
}

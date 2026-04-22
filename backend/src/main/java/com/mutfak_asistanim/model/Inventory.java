package com.mutfak_asistanim.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.mutfak_asistanim.enums.UnitType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "inventory")
public class Inventory extends BaseEntity {
	
	@Column(name = "quantity")
	private BigDecimal quantity;
	
	@Column(name = "unit_type")
	@Enumerated(EnumType.STRING)
	private UnitType unitType;
	
	@Column(name = "expiration_date")
	@JsonFormat(pattern = "dd-MM-yyyy")
	private LocalDate expirationDate;
		
	//notification
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "inventory")
	private List<Notification> notifications= new ArrayList<>(); 
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "user_id")
	private User user;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "product_id")
	private Product product;
	
}

package com.mutfak_asistanim.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.mutfak_asistanim.enums.UnitType;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoInventoryIU {
	
	@NotNull
	private BigDecimal quantity;
	
	@NotNull
	private UnitType unitType;
	
	@NotNull
	@JsonFormat(pattern = "dd-MM-yyyy")
	private LocalDate expirationDate;
	
	@NotNull
	private Long productId;
	
}

package com.mutfak_asistanim.model;

import java.sql.Date;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "refresh_token")
public class RefreshToken extends BaseEntity {
	
	@Column(name = "refresh_token")
	private String refreshToken;
	
	@Column(name = "expired_date")
	private Date expiredDate;
	
	@Column(name = "revoked")
	private Boolean revoked;
	
	@ManyToOne
	@JoinColumn(name = "user_id")
	private User user;
	
}

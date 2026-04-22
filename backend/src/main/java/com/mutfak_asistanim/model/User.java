package com.mutfak_asistanim.model;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "user")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User extends BaseEntity {
	
	@Column(name = "first_ name")
	private String firstName;
	
	@Column(name = "last_name")
	private String lastName;
	
	@Column(name = "password")
	private String pasword;
	
	//inventory
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<Inventory> inventories= new ArrayList<>();
	
	//notification
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<Notification> notifications = new ArrayList<>();
	
	//refreshToken
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<RefreshToken> refreshTokens = new ArrayList<>();
	
}

package com.mutfak_asistanim.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

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
public class User extends BaseEntity implements UserDetails {
	
	@Column(name = "first_name")
	private String firstName;
	
	@Column(name = "last_name")
	private String lastName;
	
	@Column(name = "username")
	private String username;
	
	@Column(name = "password")
	private String password;
	
	@Column(name = "email")
	private String email;
	
	//inventory
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<Inventory> inventories= new ArrayList<>();
	
	//notification
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<Notification> notifications = new ArrayList<>();
	
	//refreshToken
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	private List<RefreshToken> refreshTokens = new ArrayList<>();

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return List.of();
	}

}

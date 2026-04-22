package com.mutfak_asistanim.starter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@ComponentScan(basePackages = {"com.mutfak_asistanim"})
@EntityScan(basePackages = {"com.mutfak_asistanim"})
@EnableJpaRepositories(basePackages = {"com.mutfak_asistanim"})
@SpringBootApplication
public class MutfakAsistanimApplicationStarter {

	public static void main(String[] args) {
		SpringApplication.run(MutfakAsistanimApplicationStarter.class, args);
	}

}

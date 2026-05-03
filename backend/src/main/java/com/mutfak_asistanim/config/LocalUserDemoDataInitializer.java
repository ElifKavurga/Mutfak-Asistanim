package com.mutfak_asistanim.config;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.mutfak_asistanim.enums.CategoryType;
import com.mutfak_asistanim.enums.UnitType;
import com.mutfak_asistanim.model.Inventory;
import com.mutfak_asistanim.model.Notification;
import com.mutfak_asistanim.model.Product;
import com.mutfak_asistanim.model.Recipe;
import com.mutfak_asistanim.model.RecipeIngredient;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.InventoryRepository;
import com.mutfak_asistanim.repository.NotificationRepository;
import com.mutfak_asistanim.repository.ProductRepository;
import com.mutfak_asistanim.repository.RecipeIngredientRepository;
import com.mutfak_asistanim.repository.RecipeRepository;
import com.mutfak_asistanim.repository.UserRepository;

@Component
@Profile("local")
public class LocalUserDemoDataInitializer implements CommandLineRunner {

	private final UserRepository userRepository;
	private final ProductRepository productRepository;
	private final InventoryRepository inventoryRepository;
	private final RecipeRepository recipeRepository;
	private final RecipeIngredientRepository recipeIngredientRepository;
	private final NotificationRepository notificationRepository;
	private final BCryptPasswordEncoder passwordEncoder;

	@Value("${app.local-demo.username:edaybasn}")
	private String demoUsername;

	@Value("${app.local-demo.password:12345}")
	private String demoPassword;

	@Value("${app.local-demo.first-name:Eda}")
	private String demoFirstName;

	@Value("${app.local-demo.last-name:Ybasn}")
	private String demoLastName;

	@Value("${app.local-demo.email:edaybasn@local.mutfak}")
	private String demoEmail;

	public LocalUserDemoDataInitializer(
			UserRepository userRepository,
			ProductRepository productRepository,
			InventoryRepository inventoryRepository,
			RecipeRepository recipeRepository,
			RecipeIngredientRepository recipeIngredientRepository,
			NotificationRepository notificationRepository,
			BCryptPasswordEncoder passwordEncoder) {
		this.userRepository = userRepository;
		this.productRepository = productRepository;
		this.inventoryRepository = inventoryRepository;
		this.recipeRepository = recipeRepository;
		this.recipeIngredientRepository = recipeIngredientRepository;
		this.notificationRepository = notificationRepository;
		this.passwordEncoder = passwordEncoder;
	}

	@Override
	@Transactional
	public void run(String... args) {
		User demoUser = ensureDemoUser();
		Map<String, Product> products = ensureProducts();
		ensureRecipes(products);
		Map<String, Inventory> inventories = ensureInventories(demoUser, products);
		ensureNotifications(demoUser, inventories);
	}

	private User ensureDemoUser() {
		User user = userRepository.findByUsername(demoUsername).orElseGet(User::new);
		boolean isNew = user.getId() == null;

		user.setFirstName(demoFirstName);
		user.setLastName(demoLastName);
		user.setUsername(demoUsername);
		user.setEmail(demoEmail);

		if (isNew || user.getPassword() == null || !passwordEncoder.matches(demoPassword, user.getPassword())) {
			user.setPassword(passwordEncoder.encode(demoPassword));
		}

		if (isNew) {
			user.setCreatedAt(new Date());
		}

		return userRepository.save(user);
	}

	private Map<String, Product> ensureProducts() {
		Map<String, Product> products = new LinkedHashMap<>();
		products.put("Yumurta", findOrCreateProduct("Yumurta", CategoryType.DAIRY, "869000000001"));
		products.put("Domates", findOrCreateProduct("Domates", CategoryType.VEGETABLE, "869000000002"));
		products.put("Beyaz Peynir", findOrCreateProduct("Beyaz Peynir", CategoryType.DAIRY, "869000000003"));
		products.put("Tavuk Gogsu", findOrCreateProduct("Tavuk Gogsu", CategoryType.MEAT, "869000000004"));
		products.put("Pirinc", findOrCreateProduct("Pirinc", CategoryType.GRAIN, "869000000005"));
		products.put("Muz", findOrCreateProduct("Muz", CategoryType.FRUIT, "869000000006"));
		products.put("Yogurt", findOrCreateProduct("Yogurt", CategoryType.DAIRY, "869000000007"));
		products.put("Sut", findOrCreateProduct("Sut", CategoryType.BEVERAGE, "869000000008"));
		products.put("Ispanak", findOrCreateProduct("Ispanak", CategoryType.VEGETABLE, "869000000009"));
		return products;
	}

	private Product findOrCreateProduct(String name, CategoryType categoryType, String barcode) {
		Product product = productRepository.findByProductNameIgnoreCase(name).orElseGet(Product::new);
		if (product.getId() == null) {
			product.setCreatedAt(new Date());
		}
		product.setProductName(name);
		product.setCategoryType(categoryType);
		product.setBarcode(barcode);
		if (product.getProductImageUrl() == null || product.getProductImageUrl().isBlank()) {
			product.setProductImageUrl(null);
		}
		return productRepository.save(product);
	}

	private void ensureRecipes(Map<String, Product> products) {
		ensureRecipe(
				"Menemen",
				"Kahvalti icin hizli ve doyurucu bir tarif.",
				20,
				310,
				List.of(
						new DemoRecipeIngredient("Yumurta", "3", UnitType.PIECE, true),
						new DemoRecipeIngredient("Domates", "2", UnitType.PIECE, true),
						new DemoRecipeIngredient("Beyaz Peynir", "0.15", UnitType.KG, false)),
				products);

		ensureRecipe(
				"Tavuklu Pilav",
				"Oglen veya aksam icin temel bir ana yemek.",
				35,
				540,
				List.of(
						new DemoRecipeIngredient("Tavuk Gogsu", "0.40", UnitType.KG, true),
						new DemoRecipeIngredient("Pirinc", "0.25", UnitType.KG, true)),
				products);

		ensureRecipe(
				"Muzlu Smoothie",
				"Pratik ara ogun icecegi.",
				10,
				260,
				List.of(
						new DemoRecipeIngredient("Muz", "2", UnitType.PIECE, true),
						new DemoRecipeIngredient("Yogurt", "0.25", UnitType.KG, true),
						new DemoRecipeIngredient("Sut", "0.30", UnitType.LITER, false)),
				products);

		ensureRecipe(
				"Ispanakli Omlet",
				"Sebzeli hafif bir kahvalti secenegi.",
				18,
				330,
				List.of(
						new DemoRecipeIngredient("Ispanak", "0.20", UnitType.KG, true),
						new DemoRecipeIngredient("Yumurta", "2", UnitType.PIECE, true),
						new DemoRecipeIngredient("Beyaz Peynir", "0.10", UnitType.KG, false)),
				products);
	}

	private void ensureRecipe(
			String recipeName,
			String description,
			Integer prepTimeMinutes,
			Integer calorie,
			List<DemoRecipeIngredient> ingredients,
			Map<String, Product> products) {
		Recipe recipe = recipeRepository.findByRecipeNameIgnoreCase(recipeName).orElseGet(Recipe::new);
		if (recipe.getId() == null) {
			recipe.setCreatedAt(new Date());
		}
		recipe.setRecipeName(recipeName);
		recipe.setDescription(description);
		recipe.setPrepTimeMinutes(prepTimeMinutes);
		recipe.setCalorie(calorie);
		recipe = recipeRepository.save(recipe);

		if (recipeIngredientRepository.countByRecipeId(recipe.getId()) > 0) {
			return;
		}

		for (DemoRecipeIngredient ingredientSpec : ingredients) {
			RecipeIngredient ingredient = new RecipeIngredient();
			ingredient.setCreatedAt(new Date());
			ingredient.setRecipe(recipe);
			ingredient.setProduct(products.get(ingredientSpec.productName()));
			ingredient.setQuantity(new BigDecimal(ingredientSpec.quantity()));
			ingredient.setUnitType(ingredientSpec.unitType());
			ingredient.setRequired(ingredientSpec.required());
			recipeIngredientRepository.save(ingredient);
		}
	}

	private Map<String, Inventory> ensureInventories(User user, Map<String, Product> products) {
		Map<String, Inventory> existingInventories = new LinkedHashMap<>();
		for (Inventory inventory : inventoryRepository.findByUserId(user.getId())) {
			existingInventories.put(inventory.getProduct().getProductName(), inventory);
		}

		addInventoryIfMissing(existingInventories, user, products.get("Yumurta"), "10", UnitType.PIECE, LocalDate.now().plusDays(5));
		addInventoryIfMissing(existingInventories, user, products.get("Domates"), "6", UnitType.PIECE, LocalDate.now().plusDays(3));
		addInventoryIfMissing(existingInventories, user, products.get("Beyaz Peynir"), "0.40", UnitType.KG, LocalDate.now().plusDays(6));
		addInventoryIfMissing(existingInventories, user, products.get("Tavuk Gogsu"), "0.75", UnitType.KG, LocalDate.now().plusDays(2));
		addInventoryIfMissing(existingInventories, user, products.get("Pirinc"), "1.00", UnitType.KG, LocalDate.now().plusDays(90));
		addInventoryIfMissing(existingInventories, user, products.get("Muz"), "5", UnitType.PIECE, LocalDate.now().plusDays(4));
		addInventoryIfMissing(existingInventories, user, products.get("Yogurt"), "1.00", UnitType.KG, LocalDate.now().plusDays(1));
		addInventoryIfMissing(existingInventories, user, products.get("Sut"), "2.00", UnitType.LITER, LocalDate.now().plusDays(2));
		addInventoryIfMissing(existingInventories, user, products.get("Ispanak"), "0.30", UnitType.KG, LocalDate.now().plusDays(1));

		return existingInventories;
	}

	private void addInventoryIfMissing(
			Map<String, Inventory> inventories,
			User user,
			Product product,
			String quantity,
			UnitType unitType,
			LocalDate expirationDate) {
		if (inventories.containsKey(product.getProductName())) {
			return;
		}

		Inventory inventory = new Inventory();
		inventory.setCreatedAt(new Date());
		inventory.setUser(user);
		inventory.setProduct(product);
		inventory.setQuantity(new BigDecimal(quantity));
		inventory.setUnitType(unitType);
		inventory.setExpirationDate(expirationDate);

		Inventory savedInventory = inventoryRepository.save(inventory);
		inventories.put(product.getProductName(), savedInventory);
	}

	private void ensureNotifications(User user, Map<String, Inventory> inventories) {
		if (!notificationRepository.findByUserId(user.getId()).isEmpty()) {
			return;
		}

		createNotification(
				user,
				inventories.get("Yogurt"),
				"Yogurtun son kullanma tarihi yarin doluyor.",
				LocalDate.now());

		createNotification(
				user,
				inventories.get("Tavuk Gogsu"),
				"Tavuk Gogsunu bugun kullanirsan israfi azaltabilirsin.",
				LocalDate.now().minusDays(1));

		createNotification(
				user,
				inventories.get("Ispanak"),
				"Ispanak hizli tuketilmeli, omlet veya smoothie dusunebilirsin.",
				LocalDate.now().minusDays(2));
	}

	private void createNotification(User user, Inventory inventory, String message, LocalDate sendingDate) {
		if (inventory == null) {
			return;
		}

		Notification notification = new Notification();
		notification.setCreatedAt(new Date());
		notification.setUser(user);
		notification.setInventory(inventory);
		notification.setMessage(message);
		notification.setSendingDate(sendingDate);
		notification.setIsRead(false);
		notificationRepository.save(notification);
	}

	private record DemoRecipeIngredient(String productName, String quantity, UnitType unitType, Boolean required) {
	}
}

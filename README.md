# 📊 Promo Evaluations: Prime Day Performance Analysis

## 🧩 Project Overview  
This project evaluates the effectiveness of **Prime Day deals on Amazon**, aiming to uncover insights on promotional impact by comparing performance with other retail channels.

## 🏢 Business Context  
The organization is a **category leader** with a strong presence across major retailers such as **Walmart, Loblaw, Sobeys**, and the **fastest-growing eCommerce platform—Amazon**.  
Given the unique nature of Amazon's promotional dynamics, the company is seeking **strategic allocation of promo spending** to drive growth without unnecessary cost.

## 🎯 Objectives  
- 📈 Increase sales volume during promotional events  
- 📊 Improve baseline sales by comparing:
  - 28-day average *before* the event  
  - 28-day average *after* the event

## 🗂️ Dataset Structure  

The analysis uses four datasets:

| Table Name        | Description                                          |
|-------------------|------------------------------------------------------|
| `Products_listing` | Product-level info (UPC, Brand, Segment, Cost)       |
| `Products_retail`  | Retail info by ASIN (Product Title, MSRP, MOQ)       |
| `Sales`            | Daily sales data (ASIN, Date, Revenue, Units)        |
| `Promotion`        | Promotional spend (Billback by ASIN)                 |

![Entity Relationship Diagram](https://github.com/user-attachments/assets/2c1b1879-e857-49d1-ba27-9f2b6b1558aa)

## 🔍 Analytical Focus  
- Baseline vs. post-event comparison  
- Revenue lift and unit lift from Prime Day  
- Promotion cost vs. incremental profit (ROI analysis)

## ⚙️ Tools & Workflow  
- **SQL**: Data transformation, metric calculation  
- **Excel**: Visualization and final presentation  
- *(This SQL-to-Excel workflow is common in many retail & CPG analytics workflows, especially when communicating with cross-functional business teams)*

---

> ✨ *This project reflects hands-on experience with CPG retail data and showcases how to translate raw sales data into meaningful promotional insights.*


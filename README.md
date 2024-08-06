# 🧠 Analysis of the Relationship Between Social Freedom and Mental Health: Focus on Depression Prevalence

**Statistical Computer Programming Course, supervised by Professor Chanwook Oh**  
*May 2024*

## Overview

Welcome to the repository of the project "Analysis of the Relationship Between Social Freedom and Mental Health: Focus on Depression Prevalence". This project was developed as part of the Statistical Computer Programming course under the supervision of Professor Chanwook Oh. The primary goal of this project is to investigate the impact of national factors on depression prevalence using a random forest model.

---

## Features

### 🔍 Investigation and Analysis

- **Random Forest Model**: Used to analyze the impact of various national factors on depression prevalence.
- **Global Data Analysis**: Analyzed global data on freedom indices and depression rates from 2000 to 2020.

### 📉 Key Variable Identification

- **Important Variables**: Identified key variables influencing depression rates, focusing on social, economic, and human rights freedoms.
- **Policy Recommendations**: Offered policy recommendations to reduce depression trends based on the findings.

---

## Project Structure

### 1. Data Collection and Preparation

- **Data Sources**: 
  - Human Freedom Index data from Kaggle, covering various social, economic, and human rights freedoms across 165 countries from 2000 to 2020.
  - Mental health data from Kaggle, including depression rates and other mental health conditions from 1990 to 2019.
- **Data Preprocessing**: Handled missing values and merged datasets based on country and year.

### 2. Model Development

- **Random Forest Implementation**: Developed a random forest model to predict depression prevalence using the freedom indices as input variables.
- **Dimensionality Reduction**: Applied PCA to reduce the dimensionality of the dataset and enhance model performance.

### 3. Hyperparameter Tuning

- **Optimal Hyperparameters**: Explored various hyperparameters, focusing on `mtry` (number of variables randomly sampled as candidates at each split) and `min_n` (minimum size of terminal nodes) during model tuning.

### 4. Visualization and Analysis

- **Decision Tree Visualization**: Visualized decision trees to identify key variables significantly impacting depression diagnosis outcomes.
- **Correlation Matrices**: Created correlation matrices to explore relationships between different freedom indices.

---

## Results and Insights

- **Key Variables**: Identified that personal and civil freedoms, such as identity and relationships freedom, significantly impact depression rates.
- **Policy Recommendations**: Suggested enhancing policies that support personal freedoms and human rights to mitigate depression prevalence.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Professor Chanwook Oh for his guidance and supervision.
- The Statistical Computer Programming course for the opportunity to develop this project.

---

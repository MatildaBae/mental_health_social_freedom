# 필요한 패키지 설치 및 로드
library(readr)
library(dplyr)
library(GGally)
library(tidyverse)
library(ggplot2)
library(tidyr)
library(caTools)
library(caret)
library(randomForest)

# CSV 파일 불러오기
free <- read_csv("hfi_cc_2022.csv")
mental <- read_csv("mental_illnesses_prevalence.csv")


#### Human Freedom Index Data Preprocessing ####

# 주요 변수 추출, 2019년까지
free_df <- free_cleaned %>% filter(year<2020) %>%
  select(year, countries,
         pf_rol, pf_ss, pf_movement,
         pf_religion, pf_assembly, pf_expression, pf_identity,
         ef_government, ef_legal, ef_trade, ef_money,
         ef_regulation, hf_score)

# 각 변수별 NaN 값 수 계산
nan_count <- colSums(is.na(free_df))

# 결과 출력
nan_count

# 그룹화 및 NaN 값 카운트
nan_counts <- free_df %>%
  select(countries, ef_trade) %>%
  group_by(countries) %>%
  summarise(across(everything(), ~ sum(is.na(.))))

# 결측치 비율이 높은 변수들에 한해서
# 20년 중 결측치가 15년치보다 많은 나라들 추출
nan <- nan_counts %>%
  filter(ef_trade > 15)

# 결과 확인
print(nan)
# 'Belarus', 'Comoros', 'Djibouti', 'Iraq', 'Somalia', 'Sudan'

# 결측치가 많은 나라들 제거
free_df <- free_df %>% filter(!countries %in% c('Belarus', 'Comoros', 'Djibouti'
                                                ,'Iraq', 'Somalia', 'Sudan'))

# 다른 변수(pf_rol)로 한 번 더 진행
# 그룹화 및 NaN 값 카운트
nan_counts <- free_df %>%
  select(countries, pf_rol) %>%
  group_by(countries) %>%
  summarise(across(everything(), ~ sum(is.na(.))))

nan <- nan_counts %>%
  filter(pf_rol > 15)

# 결과 확인
print(nan)
# 'Brunei Darussalam'

free_df <- free_df %>% filter(!countries %in% c('Brunei Darussalam'))

# 결측값을 전년도 동일 변수 값으로 보강
free_filled <- free_df %>%
  arrange(countries, year) %>%
  group_by(countries) %>%
  fill(everything(), .direction = "downup") %>% 
  # 각 그룹내 결측값을 위, 아래 모두 채움
  ungroup()

# 결과 확인
free_filled

# 잘 제거 되었는지 최종 확인
nan_count <- colSums(is.na(free_filled))

# 결과 출력
nan_count


#### 시각화 ####
# 상관 행렬 그리기
ggpairs(free_filled %>% select(pf_rol, pf_ss, pf_movement, pf_religion, 
                               pf_assembly, pf_expression, pf_identity, 
                               ef_government, ef_legal, ef_trade, ef_money, 
                               ef_regulation, hf_score))

# 한국, 미국, 중국, 프랑스 추출
filtered_data <- new_data %>%
  filter(countries %in% c('South Korea', 'United States', 'China', 'France'))

# pf_ss 박스플롯 그리기
ggplot(filtered_data, aes(x = countries, y = pf_ss, fill = countries)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot of pf_ss by Country",
       x = "Country",
       y = "pf_ss") +
  theme(legend.position = "none")

# pf_expression 박스플롯 그리기
ggplot(filtered_data, aes(x = countries, y = pf_expression, fill = countries)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot of pf_expression by Country",
       x = "Country",
       y = "pf_expression") +
  theme(legend.position = "none")


#### Mental Health Data Preprocessing ####

# 연도, 나라, 우울증 변수 추출
mental_df <- mental[, c(1, 3, 5)]

# join을 위해 변수명 통일
names(mental_df) <- c('countries', 'year', 'depressive')


#### 시각화 ####
# 한국, 미국, 중국, 핀란드 추출
selected_countries <- c('Finland', 'South Korea', 'United States', 'China')
filtered_data <- subset(mental_df, countries %in% selected_countries)

# 우울증 유병률 추이 선그래프 그리기
ggplot(filtered_data, aes(x = year, y = depressive, color = countries)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Yearly trend of Depressive Disorder rate", x = "Year", 
       y = "Depressive Disorder(Share of population)") +
  theme(legend.title = element_blank())


#### What if each data has different name but same countries? ####

# data1과 data2의 나라 변수 값들이 겹치지 않는 것들 각각 추출
not_in_data2 <- setdiff(free_filled$countries, mental_df$countries)
not_in_data1 <- setdiff(mental_df$countries, free_filled$countries)

# 결과 출력
print("data1에만 있는 나라:")
print(not_in_data2)

print("data2에만 있는 나라:")
print(not_in_data1)

# 이름 변환 매핑
name_mapping <- c(
  "Korea, Rep." = "South Korea",
  "Bahamas, The" = "Bahamas",
  "Cabo Verde" = "Cape Verde",
  "Congo, Dem. Rep." = "Democratic Republic of Congo",
  "Congo, Rep." = "Congo",
  "Czech Republic" = "Czechia",
  "Egypt, Arab Rep." = "Egypt",
  "Gambia, The" = "Gambia",
  "Iran, Islamic Rep." = "Iran",
  "Kyrgyz Republic" = "Kyrgyzstan",
  "Lao PDR" = "Laos",
  "Russian Federation" = "Russia",
  "Slovak Republic" = "Slovakia",
  "Syrian Arab Republic" = "Syria",
  "Timor-Leste" = "East Timor",
  "Venezuela, RB" = "Venezuela",
  "Yemen, Rep." = "Yemen"
)

# 나라 이름 통일
free_filled$countries <- recode(free_filled$countries, !!!name_mapping)


#### 데이터 병합 ####
new_data <- inner_join(free_filled, mental_df, by=c('countries','year'))


#### Random Forest Modeling ####

# 'countries' 열 제거
new_data <- new_data %>% select(-countries)

# 'year' 열 제거
new_data <- new_data %>% select(-year)

# 데이터 분할
set.seed(123)
split <- sample.split(new_data$depressive, SplitRatio = 0.8)
train_data <- subset(new_data, split == TRUE)
test_data <- subset(new_data, split == FALSE)

# 데이터 스케일링
preProc <- preProcess(train_data, method = c("center", "scale"))
train_data_scaled <- predict(preProc, train_data)
test_data_scaled <- predict(preProc, test_data)

# 스케일링 되었는지 확인
head(train_data_scaled)

# 교차 검증 설정
train_control <- trainControl(method = "cv", number = 10)

# 랜덤 포레스트 모델 학습
set.seed(123)
rf_model <- train(depressive ~ ., data = train_data_scaled, method = "rf", 
                  trControl = train_control)

# 모델 요약
print(rf_model)


#### 변수별 기여도 분석 ####

# 변수별 기여도 출력
importance <- varImp(rf_model, scale = FALSE)

print(importance)
plot(importance)


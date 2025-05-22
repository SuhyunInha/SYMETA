# Taxonomic Composition Bubble Plot in R
##   Input: family_top30_selected.tsv
##   Output: taxonomy_bubble.pdf

# Load required packages
library(readr)        # For read_tsv()
library(dplyr)        # For data manipulation
library(tidyr)        # For pivot_longer()
library(ggplot2)      # For visualization
library(patchwork)    # For combining ggplots
library(cowplot)      # For arranging plots

# 1. Load taxonomy abundance table
meta <- read_tsv("family_top30_selected.tsv", col_types = cols())

# 2. Define colums
taxonomy_cols <- c("Phylum", "Class", "Order", "Family")
sample_cols   <- setdiff(names(meta), taxonomy_cols)

# 3. Create taxonomy factor column
meta <- meta %>%
  mutate(Taxonomy = factor(paste(Class, Order, Family, sep = " | "),
                           levels = paste(Class, Order, Family, sep = " | ")))

# 4. Create tax_table for left panel
tax_table <- meta %>%
  select(Class, Order, Family, Taxonomy) %>%
  mutate(row = as.numeric(Taxonomy))

# 5. Convert data to long format for ggplot
meta_long <- meta %>%
  pivot_longer(all_of(sample_cols), names_to = "Sample", values_to = "Abundance") %>%
  mutate(Sample = factor(Sample, levels = sample_cols))

n_row <- nrow(meta)
row_pad <- 0.5  # vertical padding

# 6. Left panel: taxonomy labels
p_left <- ggplot(tax_table) +
  geom_text(aes(x = 0.00, y = row, label = Class),  hjust = 0, size = 3.2, fontface = "italic") +
  geom_text(aes(x = 0.85, y = row, label = Order),  hjust = 0, size = 3.2, fontface = "italic") +
  geom_text(aes(x = 1.70, y = row, label = Family), hjust = 0, size = 3.2, fontface = "italic") +
  geom_segment(x = 0.80, xend = 0.80, y = 0.5, yend = n_row + .5) +
  geom_segment(x = 1.65, xend = 1.65, y = 0.5, yend = n_row + .5) +
  scale_y_reverse(limits = c(n_row + row_pad, row_pad), expand = c(0, 0)) +
  coord_cartesian(xlim = c(-0.05, 1.95), clip = "off") +
  theme_void() +
  theme(plot.margin = margin(5, 60, 5, 5))

# 7. Class-level break lines
class_break <- tax_table %>%
  mutate(prev_class = lag(Class)) %>%
  filter(!is.na(prev_class) & Class != prev_class) %>%
  mutate(y = row - 0.5)

bottom_break <- tibble(y = n_row + 0.5)
line_breaks <- bind_rows(class_break %>% select(y), bottom_break)

p_left <- p_left +
  geom_segment(data = line_breaks,
               aes(x = -0.05, xend = 2.5, y = y, yend = y),
               linewidth = .4)

# 8. Right panel: abundance bubble plot
p_right <- ggplot(meta_long,
                  aes(x = Sample, y = Taxonomy,
                      size = Abundance, fill = Taxonomy)) +
  geom_point(shape = 21, colour = "black", alpha = .4) +
  scale_size(range = c(0, 15), name = "Abundance (%)") +
  scale_y_discrete(limits = rev(levels(meta$Taxonomy)),
                   expand = expansion(add = c(row_pad, row_pad))) +
  scale_fill_hue(direction = -1) +
  theme_bw() +
  xlab(NULL) + ylab(NULL) +
  theme(axis.text.x = element_text(angle = 90, vjust = .5, hjust = 1, size = 8),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.title = element_text(size = 9),
        legend.text  = element_text(size = 8),
        legend.position = "right",
        plot.margin  = margin(5, 5, 5, 0)) +
  guides(fill = "none")

# 9. Combine both panels
final_plot <- plot_grid(p_left, p_right, ncol = 2, rel_widths = c(0.6, 1), align = "h", axis = "tb")
print(final_plot)

# 10. Save as PDF (same size as current plot window)
wh <- dev.size("in")
ggsave("taxonomy_bubble.pdf", plot = final_plot, device = cairo_pdf,
       width = wh[1], height = wh[2], units = "in")

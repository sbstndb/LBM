/********************  HEADERS  *********************/
#include "../include/lbm_config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/****************  GLOBAL VARS ****************/

lbm_config_t lbm_gbl_config;

/*****************  FUNCTION  *******************/
/**
 * Application des valeurs par defaut au cas ou l'utilisateur en définirait pas
 *tout dans le fichier de configuration.
 **/
void setup_default_values(void) {
  // directisation.
  lbm_gbl_config.iterations = 10000;
  lbm_gbl_config.width = 800;
  lbm_gbl_config.height = 100;
  // obstacle
  lbm_gbl_config.obstacle_x = 0.0;
  lbm_gbl_config.obstacle_y = 0.0;
  lbm_gbl_config.obstacle_r = 0.0;
  // flow
  lbm_gbl_config.inflow_max_velocity = 0.1;
  lbm_gbl_config.reynolds = 100;
  // result output file
  lbm_gbl_config.output_filename = NULL;
  lbm_gbl_config.write_interval = 50;
}

/*****************  FUNCTION  *******************/
/**
 * Calcul des paramètres dérivés.
 **/
void update_derived_parameter(void) {
  // derived parameter
  lbm_gbl_config.kinetic_viscosity =
      (lbm_gbl_config.inflow_max_velocity * 2.0 * lbm_gbl_config.obstacle_r /
       lbm_gbl_config.reynolds);
  lbm_gbl_config.relax_parameter =
      1.0 / (3.0 * lbm_gbl_config.kinetic_viscosity + 1.0 / 2.0);
}

/*****************  FUNCTION  *******************/
/**
 * Chargement de la config depuis le fichier.
 **/
void load_config(const char *filename) {
  // vars
  FILE *fp;
  char buffer[1024];
  char buffer2[1024];
  int intValue;
  double doubleValue;
  int line = 0;

  // open the config file
  fp = fopen(filename, "r");
  if (fp == NULL) {
    perror(filename);
    abort();
  }

  // load default values
  setup_default_values();

  // loop on lines
  while (fgets(buffer, 1024, fp) != NULL) {
    line++;
    if (buffer[0] == '#') {
      // comment, nothing to do
    } else if (sscanf(buffer, "iterations = %d\n", &intValue) == 1) {
      lbm_gbl_config.iterations = intValue;
    } else if (sscanf(buffer, "width = %d\n", &intValue) == 1) {
      lbm_gbl_config.width = intValue;
      if (lbm_gbl_config.obstacle_x == 0.0)
        lbm_gbl_config.obstacle_x = (lbm_gbl_config.width / 5.0 + 1.0);
    } else if (sscanf(buffer, "height = %d\n", &intValue) == 1) {
      lbm_gbl_config.height = intValue;
      if (lbm_gbl_config.obstacle_r == 0.0)
        lbm_gbl_config.obstacle_r = (lbm_gbl_config.height / 10.0 + 1.0);
      if (lbm_gbl_config.obstacle_y == 0.0)
        lbm_gbl_config.obstacle_y = (lbm_gbl_config.height / 2.0 + 3.0);
    } else if (sscanf(buffer, "obstacle_r = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.obstacle_r = doubleValue;
    } else if (sscanf(buffer, "obstacle_x = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.obstacle_x = doubleValue;
    } else if (sscanf(buffer, "obstacle_y = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.obstacle_y = doubleValue;
    } else if (sscanf(buffer, "inflow_max_velocity = %lf\n", &doubleValue) ==
               1) {
      lbm_gbl_config.inflow_max_velocity = doubleValue;
    } else if (sscanf(buffer, "reynolds = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.reynolds = doubleValue;
    } else if (sscanf(buffer, "kinetic_viscosity = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.kinetic_viscosity = doubleValue;
    } else if (sscanf(buffer, "relax_parameter = %lf\n", &doubleValue) == 1) {
      lbm_gbl_config.relax_parameter = doubleValue;
    } else if (sscanf(buffer, "write_interval = %d\n", &intValue) == 1) {
      lbm_gbl_config.write_interval = intValue;
    } else if (sscanf(buffer, "output_filename = %s\n", buffer2) == 1) {
      lbm_gbl_config.output_filename = strdup(buffer2);
    } else {
      fprintf(stderr, "Invalid config option line %d : %s\n", line, buffer);
      abort();
    }
  }

  // check error
  if (!feof(fp)) {
    perror(filename);
    abort();
  }

  update_derived_parameter();
}

/*****************  FUNCTION  *******************/
/**
 * Nettoyage de la mémoire dynamique de la config.
 **/
void config_cleanup(void) { free((void *)lbm_gbl_config.output_filename); }

/*****************  FUNCTION  *******************/
/**
 * Affichage de la config.
 **/
void print_config(void) {
#if VERBOSE
  printf("=================== CONFIG ===================\n");
  // discretisation
  printf("%-20s = %d\n", "iterations", lbm_gbl_config.iterations);
  printf("%-20s = %d\n", "width", lbm_gbl_config.width);
  printf("%-20s = %d\n", "height", lbm_gbl_config.height);
  // obstacle
  printf("%-20s = %lf\n", "obstacle_r", lbm_gbl_config.obstacle_r);
  printf("%-20s = %lf\n", "obstacle_x", lbm_gbl_config.obstacle_x);
  printf("%-20s = %lf\n", "obstacle_y", lbm_gbl_config.obstacle_y);
  // flow parameters
  printf("%-20s = %lf\n", "reynolds", lbm_gbl_config.reynolds);
  printf("%-20s = %lf\n", "reynolds", lbm_gbl_config.reynolds);
  printf("%-20s = %lf\n", "inflow_max_velocity",
         lbm_gbl_config.inflow_max_velocity);
  // results
  printf("%-20s = %s\n", "output_filename", lbm_gbl_config.output_filename);
  printf("%-20s = %d\n", "write_interval", lbm_gbl_config.write_interval);
  printf("------------ Derived parameters --------------\n");
  printf("%-20s = %lf\n", "kinetic_viscosity",
         lbm_gbl_config.kinetic_viscosity);
  printf("%-20s = %lf\n", "relax_parameter", lbm_gbl_config.relax_parameter);
  printf("==============================================\n");
#endif
}

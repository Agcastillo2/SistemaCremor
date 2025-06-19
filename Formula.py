def calcular_nata(self):
    self.nata_gramos = self.leche_litros * (0.75*self.grasa_promedio + 0.01*self.densidad_promedio + 0.15*self.lactosa_promedio) * 18 * self.dias_calculo / 10
#include "alphas.h"
#include "LHAPDF/LHAPDF.h"

extern "C" {
CAlphaS *mkAlphaS(double mt, double mz, double alpha) {
    LHAPDF::AlphaS *as = new LHAPDF::AlphaS_ODE();
    as->setOrderQCD(5);
    as->setQuarkMass(6, mt);
    as->setMZ(mz);
    as->setAlphaSMZ(alpha);

    return reinterpret_cast<CAlphaS *>(as);
}

double alphasQ(CAlphaS *as_c, double q) {
    LHAPDF::AlphaS *as = reinterpret_cast<LHAPDF::AlphaS *>(as_c);
    return as->alphasQ(q);
}
}

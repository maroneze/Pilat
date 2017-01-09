float float_interval(float,float);

int main(){
  float x,y;
  float k;
  while(x < 4){
    k=float_interval(-0.1,0.1);
    x = 0.68 * (x-y) + k;
    y = 2*0.68*y + x;

  }

  return 1;

}
/*
Invariant generated : 
1. * (x * x) + 1. * (y * y) <= 14.892578125

Interval notation :
x = [-3.86,3.86];
y = [-3.86,3.86];
*/

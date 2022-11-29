using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Macaron_Die : MonoBehaviour
{
    private int hp;
    // Start is called before the first frame update
    void Start()
    {
       hp = this.GetComponent<Macaron>().gHP;
    }

    // Update is called once per frame
    void Update()
    {
        if(hp == 0)
        {
            this.GetComponent<Macaron>().CutDamage();
        }
    }
}

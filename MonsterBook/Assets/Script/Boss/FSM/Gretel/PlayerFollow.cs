using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerFollow : MonoBehaviour
{
    // Start is called before the first frame update

    public GameObject Target;
    public int Type;

    void Start()
    {
        gameObject.transform.position = Target.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        if (Type == 1)
        {
            gameObject.transform.position = new Vector3(Target.transform.position.x, 10, Target.transform.position.z);  //그레텔 리깅애니메이션 Follow
        }
        else if(Type == 2)
        {
            gameObject.transform.position = new Vector3(Target.transform.position.x-6, 0, Target.transform.position.z); //그레텔 칼공격 Follow
        }
        else if(Type == 0)
        {
            gameObject.transform.position = new Vector3(Target.transform.position.x, 0, Target.transform.position.z);   //그레텔과 플레이어 거리 측정용(점프로 인한 거리 변환 방지용)
        }
    }
}
